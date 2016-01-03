Template.teams.helpers(
    selected: () ->
        this._id == Template.instance().data?.selectedTeam
    teams: () ->
        sort = { sort: { name: 1 } }
        if Template.instance().data.classSort?
            sort = { sort: { class: 1, name: 1 } }
        if this.class?
            Teams.find {class: this.class}, sort
        else
            Teams.find({}, sort)
)
