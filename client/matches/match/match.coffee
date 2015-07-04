Template.match.helpers (
    wonA: () ->
        this.teamAId == this.winTeam
    wonB: () ->
        this.teamBId == this.winTeam
    defaultWin: () ->
        return this.defaultWin
    teamAName: () ->
        Teams.findOne(this.teamAId).name
    teamBName: () ->
        Teams.findOne(this.teamBId).name
)

Template.match.events (
    "click .delete": () ->
        if confirm "Really delete match?"
            Matches.remove this._id

)
