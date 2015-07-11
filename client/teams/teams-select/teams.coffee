Template.teams.helpers(
    selected: () ->
        this._id == Template.instance().data?.selectedTeam
    teams: () ->
        sort = { sort: {name: 1} }
        if this.block?
            Teams.find {block: this.block}, sort
        else
            Teams.find({}, sort)
)
