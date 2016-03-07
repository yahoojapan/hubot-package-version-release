assert = require 'power-assert'
sinon  = require 'sinon'
nock   = require 'nock'

http = require 'scoped-http-client'

PublishRelease = require '../src/publish'

describe 'class PublishRelease', ->

  user = ''
  robot = ''
  logger = ''
  publishRelease = ''

  GITHUB_API_BASE = 'https://api.github.com'
  GITHUB_RAW_URL  = 'https://raw.github.com'

  beforeEach () ->

    logger = {
       error: sinon.spy()
       info: sinon.spy()
       debug:  sinon.spy()
    }

    robot = {
      http: http.create
      logger: logger
    }

    publishRelease = new PublishRelease {
      fullName: 'owner/repo'
      branch: 'release'
      rawUrl: GITHUB_RAW_URL
    }, robot

  afterEach ->
    logger.error.reset()
    logger.info.reset()
    logger.debug.reset()
    nock.cleanAll()

  describe 'constructor', ->

    it 'rawUrl', ->
      assert publishRelease.rawUrl == 'https://raw.github.com'

    it 'fullName', ->
      assert publishRelease.fullName == 'owner/repo'

    it 'branch', ->
      assert publishRelease.branch == 'release'

  describe 'publish', ->
    packageJsonUrl    = 'https://raw.github.com/owner/repo/release/package.json'
    githubReleaseUrl  = 'https://api.github.com/repos/owner/repo/releases'

    context 'when package.json is not foud', ->
      beforeEach ->
        nock(packageJsonUrl).get('').replyWithError {error: 'error'}

      it 'error message', (done) ->
        publishRelease.publish (err, res) ->
          assert err == "#{packageJsonUrl} is inaccessible"
          done()

      it 'error log', (done) ->
        publishRelease.publish (err, res) ->
          assert robot.logger.error.calledOnce
          done()

    describe 'version field of package.json', ->
      context 'when package.json is not exists', ->
        beforeEach ->
          nock(packageJsonUrl).get('').reply 200, 'Not Found'

        it 'error message', (done) ->
          publishRelease.publish (err, res) ->
            assert err == 'package.json is not exists'
            done()

      context 'when package.json has not version field', ->
        beforeEach ->
          nock(packageJsonUrl).get('').reply 200, {}

        it 'error message', (done) ->
          publishRelease.publish (err, res) ->
            assert err == "version field is invalid. require [n.n.n] but [not found]"
            done()

      context 'when package.json has invalid version field', ->
        beforeEach ->
          nock(packageJsonUrl).get('').reply 200, {version: 'a'}

        it 'error message', (done) ->
          publishRelease.publish (err, res) ->
            assert err == "version field is invalid. require [n.n.n] but [a]"
            done()

    context 'when user has not permission', ->
      beforeEach ->
        nock(packageJsonUrl).get('').reply 200, {version: '1.10.100'}
        nock(githubReleaseUrl).post('').reply 401, {message: 'github api error'}

      it 'error message', (done) ->
        publishRelease.publish (err, res) ->
          assert err == "github api error [github api error]"
          done()

      it 'error log', (done) ->
        publishRelease.publish (err, res) ->
          assert robot.logger.error.calledOnce
          done()

    context 'a tag already exists', ->
      beforeEach ->
        nock(packageJsonUrl).get('').reply 200, {version: '1.10.100'}
        nock(githubReleaseUrl).post('')
        .reply 401, {message: 'Validation Failed'}

      it 'error message', (done) ->
        publishRelease.publish (err, res) ->
          assert err == 'validation failed. maybe a tag which has same version is already exists'

          done()

    context 'success', ->
      beforeEach ->
        nock(packageJsonUrl).get('').reply 200, {version: '1.10.100'}
        nock(githubReleaseUrl).post('', {
          tag_name: '1.10.100'
          target_commitish: 'release'
          name: '1.10.100'
          body: ''
          draft: false
          prerelease: false
        }).reply 200, {html_url: 'html_url'}

      it 'ok message', (done) ->
        publishRelease.publish (err, res) ->
          assert res == 'SUCCESS!! publish release 1.10.100 based release\nhtml_url'
          done()


