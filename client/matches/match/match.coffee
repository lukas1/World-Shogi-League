Template.match.helpers
    isAdmin: () ->
        isAdmin()
    wonA: () ->
        return teamWonMatch this.teamAId, this._id
    wonB: () ->
        return teamWonMatch this.teamBId, this._id
    matchPointsA: () ->
        Math.max(0, teamBoardsWinsForMatch this.teamAId, this._id)
    matchPointsB: () ->
        Math.max(0, teamBoardsWinsForMatch this.teamBId, this._id)
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
