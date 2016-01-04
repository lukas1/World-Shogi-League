Template.teams.helpers(
    selected: () ->
        this._id == Template.instance().data?.selectedTeam
    classes: () ->
        return CLASSES
    teams: (classOptGroup) ->
        sort = { sort: { name: 1 } }
        if Template.instance().data.classSort?
            sort = { sort: { class: 1, name: 1 } }
        if this.class?
            Teams.find {class: this.class}, sort
        else
            Teams.find({class: classOptGroup}, sort)
)
