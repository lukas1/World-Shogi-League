thisTeamData = () ->
    return Teams.findOne Template.instance().data.params._id

Template.teamProfile.helpers
    teamData: thisTeamData
