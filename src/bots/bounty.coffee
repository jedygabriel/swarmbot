# Description:
#   Create a bounty
#
# Commands:
#   hubot I'd like <suggested improvement for swarmbot>
#   hubot upvote <proposal name>

# Hidden Commands:
#   hubot create proposal <proposal name> for <number of coins> [in <community>]
#   hubot rate <proposal name> <value>% [in <community name]
#   hubot award proposal <proposal name> to <slack username> [in <community>]
#   hubot show proposal <proposal name> [in <community name>]


# Not in use:
#   hubot list bounties [in <community name>]
#   hubot (<bounty_name>) bounty add me - add me to the bounty
#   hubot get balance - get your current balance
#   hubot (<bounty_name>) bounty add (me|<user>) - add me or <user> to bounty
#   hubot (<bounty_name>) bounty add (me|<user>) - add me or <user> to bounty
#   hubot (<bounty_name>) bounty remove (me|<user>) - remove me or <user> from bounty
#   hubot (<bounty_name>) bounty (empty|clear) - clear bounty list
#   hubot (delete|remove) <bounty_name> bounty - delete bounty called <bounty_name>
#   hubot (<bounty_name>) bounty -1 - remove me from the bounty
#   hubot (<bounty_name>) bounty count - list the current size of the bounty
#   hubot (<bounty_name>) bounty (list|show) - list the people in the bounty

{log, p, pjson} = require 'lightsaber'
{ values } = require 'lodash'
{ Claim } = require 'trust-exchange'
swarmbot = require '../models/swarmbot'
Proposal = require '../models/proposal'
DCO = require '../models/dco'
ProposalsController = require '../controllers/proposals-controller'

module.exports = (robot) ->
  robot.respond /show proposal\s+(.*)(?: in (.+))?\s*$/i, (msg) ->
    [all, proposalName, community] = msg.match
    log "MATCH 'show proposal' : #{all}"
    new ProposalsController().show(msg, { proposalName, community })

  robot.respond /award proposal\s+(.+)\s+to\s+(.+?)(?:\s+in (.+))?\s*$/i, (msg) ->
    [all, proposalName, awardee, dcoKey] = msg.match
    log "MATCH 'award proposal' : #{pjson msg.match}"
    new ProposalsController().award(msg, { proposalName, awardee, dcoKey })

  robot.respond /create proposal\s+(.+)\s+for $(\d+)(?: in\s+(.+))?\s*$/i, (msg) ->
    [all, proposalName, amount, community] = msg.match
    log "MATCH 'create proposal' : #{all}"
    new ProposalsController().create(msg, { proposalName, amount, community })

  robot.respond /rate\s+(.+)\s+([\d.]+)%(?:\s+(?:in|for)\s+(.*))?\s*$/i, (msg) ->
    [all, proposalName, rating, community] = msg.match
    log "MATCH 'rate' : #{all}"
    new ProposalsController().rate(msg, { community, proposalName, rating })

  robot.respond /upvote\s+(.+)\s*$/i, (msg) ->
    [all, proposalName] = msg.match
    rating = 95
    community = undefined
    log "MATCH 'upvote' : #{all}"
    new ProposalsController().rate(msg, { community, proposalName, rating })

  robot.respond /:\+1:\s+(.+)\s*$/i, (msg) ->
    [all, proposalName] = msg.match
    rating = 95
    community = undefined
    log "MATCH 'upvote' : #{all}"
    new ProposalsController().rate(msg, { community, proposalName, rating })

  robot.respond /downvote\s+(.+)\s*$/i, (msg) ->
    [all, proposalName] = msg.match
    rating = 5
    community = undefined
    log "MATCH 'rate' : #{all}"
    new ProposalsController().rate(msg, { community, proposalName, rating })

  robot.respond /i(?:[’']d| would) like\s+(.+)$/i, (msg) ->
    suggestion = msg.match[1]
    log "MATCH 'i'd like' : #{msg.match[0]}"
    new ProposalsController().swarmbotSuggestion(msg, { suggestion })


  # robot.respond /award (.+) bounty to (.+)$/i, (msg) ->
  #   [all, bountyName, awardee] = msg.match
  #   activeUser = robot.whose msg
  #
  #   dco = DCO.find 'save-the-world'
  #
  #   usersRef = swarmbot.firebase().child('users')
  #   usersRef.orderByChild("slack_username").equalTo(awardee).on 'value', (snapshot) ->
  #       v = snapshot.val()
  #       vals = values v
  #       p "vals", vals[0]
  #       awardeeAddress = vals[0].btc_address
  #       p "address", awardeeAddress
  #
  #       # p "awardee", awardeeAddress values btc_address
  #       if(awardeeAddress)
  #         dco.awardBounty {bountyName, awardeeAddress}
  #         message = "Awarded bounty to #{awardee}"
  #         msg.send message
  #       else
  #         msg.send "User not yet registered"


  # robot.respond /create (\S*) bounty (\S*) coins?.*/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bountySize = msg.match[2]
  #   if bounty = Bounty.get bountyName
  #     message = ResponseMessage.bountyAlreadyExists bounty
  #   else
  #     bounty = Bounty.create bountyName, bountySize
  #     message = ResponseMessage.bountyCreated bounty
  #   msg.send message

  # robot.respond /(delete|remove) (\S*) bounty ?.*/i, (msg) ->
  #   bountyName = msg.match[2]
  #   if Config.isAdmin(msg.message.user.name)
  #     if bounty = Bounty.get bountyName
  #       bounty.destroy()
  #       message = ResponseMessage.bountyDeleted bounty
  #     else
  #       message = ResponseMessage.bountyNotFound bountyName
  #     msg.send message
  #   else
  #     msg.reply ResponseMessage.adminRequired()
  #
  # robot.respond /list bounties ?.*/i, (msg) ->
  #   bounties = Bounty.all()
  #   msg.send ResponseMessage.listBountys bounties
  #
  # robot.respond /(\S+) bounty add (\S+)$/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
  #   user = UserNormalizer.normalize(msg.message.user.name, msg.match[2])
  #   isMemberAdded = bounty.addMember user
  #   if isMemberAdded
  #     message = ResponseMessage.memberAddedToBounty(user, bounty)
  #   else
  #     message = ResponseMessage.memberAlreadyAddedToBounty(user, bounty)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty add me?.*/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
  #   user = UserNormalizer.normalize(msg.message.user.name)
  #   isMemberAdded = bounty.addMember user
  #   if isMemberAdded
  #     message = ResponseMessage.memberAddedToBounty(user, bounty)
  #   else
  #     message = ResponseMessage.memberAlreadyAddedToBounty(user, bounty)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty remove (\S*) ?.*/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
  #   user = UserNormalizer.normalize(msg.message.user.name, msg.match[2])
  #   isMemberRemoved = bounty.removeMember user
  #   if isMemberRemoved
  #     message = ResponseMessage.memberRemovedFromBounty(user, bounty)
  #   else
  #     message = ResponseMessage.memberAlreadyOutOfBounty(user, bounty)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty -1/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
  #   user = UserNormalizer.normalize(msg.message.user.name)
  #   isMemberRemoved = bounty.removeMember user
  #   if isMemberRemoved
  #     message = ResponseMessage.memberRemovedFromBounty(user, bounty)
  #   else
  #     message = ResponseMessage.memberAlreadyOutOfBounty(user, bounty)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty count$/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   message = if bounty then ResponseMessage.bountyCount(bounty) else ResponseMessage.bountyNotFound(bountyName)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty (list|show)$/i, (msg) ->
  #   bountyName = msg.match[1]
  #   bounty = Bounty.getOrDefault(bountyName)
  #   message = if bounty then ResponseMessage.listBounty(bounty) else ResponseMessage.bountyNotFound(bountyName)
  #   msg.send message
  #
  # robot.respond /(\S*)? bounty (clear|empty)$/i, (msg) ->
  #   if Config.isAdmin(msg.message.user.name)
  #     bountyName = msg.match[1]
  #     if bounty = Bounty.getOrDefault bountyName
  #       bounty.clear()
  #       message = ResponseMessage.bountyCleared bounty
  #     else
  #       message = ResponseMessage.bountyNotFound bountyName
  #     msg.send message
  #   else
  #     msg.reply ResponseMessage.adminRequired()
  #
  # robot.respond /upgrade bounties$/i, (msg) ->
  #   bounties = {}
  #   for index, bounty of robot.brain.data.bounties
  #     if bounty instanceof Array
  #       bounties[index] = new Bounty index, bounty
  #     else
  #       bounties[index] = bounty
