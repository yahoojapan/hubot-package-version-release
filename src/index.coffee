# Description:
#  create github release from package.json
#
# Dependencies:
#   githubot
#
# Configuration:
#   HUBOT_GITHUB_TOKEN         (required)
#   HUBOT_GITHUB_BASE_BRANCH   (optional)
#   HUBOT_GITHUB_OWNER         (optional)
#   HUBOT_GITHUB_RAW           (optional)
#   HUBOT_GITHUB_API           (optional)
#
# Commands:
#   hubot publish release <[owner/]repo> from package.json
#
# Author:
#   Tatshro Mitsuno <tmitsuno@yahoo-corp.jp>

PublishRelease = require './publish'

module.exports = (robot) ->

  robot.respond /publish release ([\w\-\.\/]+) from package.json/i, (msg) ->

    if msg.match[1].indexOf('/') is -1
      if process.env.HUBOT_GITHUB_OWNER?
        fullName = process.env.HUBOT_GITHUB_OWNER + '/' + msg.match[1]
      else
        msg.send 'owner not specified'
        return
    else
      fullName = msg.match[1]

    publishRelease = new PublishRelease {
      fullName: fullName
      branch: process.env.HUBOT_GITHUB_BASE_BRANCH || 'release'
      rawUrl: process.env.HUBOT_GITHUB_RAW || 'https://raw.github.com'
    }, robot

    publishRelease.publish (err, res) ->
      if err?
        msg.send err
      else 
        msg.send res

  # [TODO] webhooks entry point
