Template.match.helpers
    isAdmin: () ->
        isAdmin()
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
            Meteor.call "removeMatch", this._id, (error, result) ->
                if error
                    alert "Failed to remove this match."

    "click .match": (event, tpl) ->
        event.stopPropagation()
        Router.go Routes.games.name, { _id: this._id }
