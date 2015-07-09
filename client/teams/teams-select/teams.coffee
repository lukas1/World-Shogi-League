Template.teams.helpers(
    teams: () ->
        sort = { sort: {name: 1} }
        if this.block?
            Teams.find {block: this.block}, sort
        else
            Teams.find({}, sort)
)
