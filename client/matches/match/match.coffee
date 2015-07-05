Template.match.helpers (
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
)

Template.match.events (
    "click .delete": () ->
        if confirm "Really delete match?"
            Matches.removeMatch this._id

)
