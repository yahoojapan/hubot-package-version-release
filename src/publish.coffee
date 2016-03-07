async = require 'async'

class PublishRelease
  constructor: (options, @robot) ->
    {@fullName, @branch, @rawUrl} = options

  publish: (done) ->
    self = @
    logger = self.robot.logger
    fullName = @fullName
    github = require('githubot')(@robot)

    async.waterfall [
      (callback) -> getPackageJsonVersion.call self, callback
    ], (err, res) ->
      if err?
        done err, null
        return
      version = res

      github = (require 'githubot')(self.robot)
      github.handleErrors (response) ->
        logger.error response
        if response.body.indexOf('Validation Failed') isnt -1
          done 'validation failed. maybe a tag which has same version is already exists', null
        else
          done "github api error [#{response.error}]", null

      data = {
        tag_name: version
        target_commitish: self.branch
        name: version
        body: ''
        draft: false
        prerelease: false
      }

      github.post "repos/#{fullName}/releases", data, (result) ->
        done(null, "SUCCESS!! publish release #{version} based #{self.branch}\n#{result.html_url}")

  # private method

  getPackageJsonVersion = (asyncCb) ->
    self = @
    logger = self.robot.logger

    url = "#{self.rawUrl}/#{self.fullName}/#{self.branch}/package.json"
    self.robot.http url
      .get() (err, res, body) ->

        if err?
          logger.error JSON.stringify err
          asyncCb "#{url} is inaccessible", null
          return

        try
          json = JSON.parse body
        catch e
          logger.error e
          asyncCb 'package.json is not exists', null
          return

        if json.version? and /[0-9]+\.[0-9]+\.[0-9]+/.test json.version
          asyncCb(null, json.version)
        else
          version = json.version || 'not found'
          logger.error 'version field is invalid [#{version}]'
          asyncCb "version field is invalid. require [n.n.n] but [#{version}]", null

module.exports = PublishRelease


