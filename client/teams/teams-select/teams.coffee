Template.teams.helpers(
    selected: () ->
        this._id == Template.instance().data?.selectedTeam
    teams: () ->
        sort = { sort: { name: 1, class: 1 } }
        if this.class?
            Teams.find {class: this.class}, sort
        else
            Teams.find({}, sort)
)
