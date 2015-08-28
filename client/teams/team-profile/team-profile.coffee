teamId = () ->
    Template.instance().data.params._id

thisTeamData = () ->
    return Teams.findOne Template.instance().data.params._id

Template.teamProfile.helpers
    teamData: thisTeamData
    teamMembers: () ->
        Meteor.users.find { 'profile.teamId': teamId() }
