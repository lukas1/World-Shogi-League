Template.match.helpers (
    wonA: () ->
        this.teamAId == this.winTeam
    wonB: () ->
        this.teamBId == this.winTeam
    defaultWin: () ->
        return this.defaultWin
    teamAName: () ->
        Teams.findOne({_id: this.teamAId}).name
    teamBName: () ->
        Teams.findOne({_id: this.teamBId}).name
)

Template.match.events (
    "click .delete": () ->
        if confirm "Really delete match?"
            Matches.remove this._id

)
