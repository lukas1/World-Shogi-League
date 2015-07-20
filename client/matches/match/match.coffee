Template.match.helpers
    wonA: () ->
        this.teamAId == this.winTeam
    wonB: () ->
        this.teamBId == this.winTeam
    defaultWin: () ->
        return this.defaultWin
    teamA: () ->
        Teams.findOne(this.teamAId)
    teamB: () ->
        Teams.findOne(this.teamBId)

Template.match.events
    "click .delete": (event, tpl) ->
        event.stopPropagation()
        return false if not Meteor.userId()?
        if confirm "Really delete match?"
            Matches.removeMatch this._id
    "click .match": (event, tpl) ->
        event.stopPropagation()
        Router.go 'games', { _id: this._id }
