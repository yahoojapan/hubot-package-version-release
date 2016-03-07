assert = require 'power-assert'
sinon  = require 'sinon'
nock   = require 'nock'

Robot       = require "hubot/src/robot"
TextMessage = require("hubot/src/message").TextMessage;

path = require 'path'

delete process.env.HUBOT_GITHUB_TOKEN
delete process.env.HUBOT_GITHUB_BASE_BRANCH
delete process.env.HUBOT_GITHUB_OWNER
delete process.env.HUBOT_GITHUB_RAW
delete process.env.HUBOT_GITHUB_API

describe 'publish release', ->
  
  user = ''
  robot = ''
  logger = ''
  publishRelease = ''

  beforeEach () ->

    logger = {
       error: sinon.spy()
       info: sinon.spy()
       debug:  sinon.spy()
    }

    robot = new Robot(null, 'mock-adapter', true, 'hubot');
    robot.logger = logger
    robot.adapter.on 'connected', ->
      robot.loadFile path.resolve('.', 'src'), 'index.coffee'

      user = robot.brain.userForId "1", {
        name: "mocha"
        room: "#mocha"
      }

    robot.run()

  afterEach ->
    logger.error.reset()
    logger.info.reset()
    logger.debug.reset()
    nock.cleanAll()

    robot.server.close()
    robot.shutdown()

  context 'when call `publish release ...` with owner', ->
    target = 'owner/repo'

    context 'when has HUBOT_GITHUB_OWNER', ->
      process.env.HUBOT_GITHUB_OWNER = 'owner2'

      it 'use user input', (done) ->
        nock('https://raw.github.com')
          .get(/.*\/owner\/repo\/.*/)
          .reply 200, {}

        robot.adapter.on 'send', (envelope, strings) ->
          assert nock.isDone()
          done()

        robot.adapter.receive new TextMessage user, "hubot publish release #{target} from package.json"

  context 'when call `publish release ...` without owner', ->
    target = 'repo'

    context 'when has HUBOT_GITHUB_OWNER', ->
      it 'environment value / user input ', (done) ->
        process.env.HUBOT_GITHUB_OWNER = 'owner2'
        nock('https://raw.github.com')
          .get(/.*\/owner2\/repo\/.*/)
          .reply 200, {}

        robot.adapter.on 'send', (envelope, strings) ->
          assert nock.isDone()
          done()

        robot.adapter.receive new TextMessage user, "hubot publish release #{target} from package.json"

