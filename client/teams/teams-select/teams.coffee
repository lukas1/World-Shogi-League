Template.teams.helpers(
    selected: () ->
        this._id == Template.instance().data?.selectedTeam
    classes: () ->
        return CLASSES
    teams: (classOptGroup) ->
        sort = { sort: { name: 1 } }
        if Template.instance().data.classSort?
            sort = { sort: { class: 1, name: 1 } }
        filter = {}

        if this.class?
            filter = {class: this.class}
        else if classOptGroup?.length
            filter = {class: classOptGroup}

        Teams.find(filter, sort)
)
