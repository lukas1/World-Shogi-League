teamId = () ->
    Template.instance().data.params._id

thisTeamData = () ->
    return Teams.findOne Template.instance().data.params._id

matchOpponentTeam = (matchId) ->
    matchData = Matches.findOne matchId
    opponentTeamId = matchData.teamBId if matchData?.teamAId == teamId()
    opponentTeamId = matchData.teamAId if matchData?.teamBId == teamId()
    if opponentTeamId?
        return Teams.findOne opponentTeamId
    else
        return {}

Template.teamProfile.helpers
    teamData: thisTeamData
    teamMembers: () ->
        Meteor.users.find { 'profile.teamId': teamId() }
    matches: () ->
        filter = { $or: [ { teamAId: teamId() }, { teamBId: teamId() } ] }
        sort = { sort: { matchEndDate: -1 } }
        Matches.find filter, sort
    matchOpponentTeamName: (matchId) ->
        teamData = matchOpponentTeam matchId
        return teamData?.name

Template.teamProfile.events
    "click .matchDetail": (event, template) ->
        matchId = $(event.target).attr('id').replace 'match', ''
        Router.go Routes.games.name, { _id: matchId }
