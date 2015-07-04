Template.match.helpers (
    wonA: () ->
        this.teamAId == this.winTeam
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
