userId = () ->
    Template.instance().data.params._id

userData = () ->
    return Meteor.users.findOne userId()

wins = () ->
    Boards.find({ playerId: userId(), win:true }).count()

losses = () ->
    Boards.find({ playerId: userId(), win:false }).count()

Template.userProfile.helpers
    userData: userData

    teamData: ->
        Teams.findOne userData().profile.teamId

    wins: wins

    losses: losses

    winRatio: ->
        allGames = Boards.find(
            { playerId: userId(), win: {$exists: false} }
        ).count()
        Math.round((wins()/allGames) * 100)
