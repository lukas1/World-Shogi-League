Template.teams.helpers(
    teams: () ->
        if this.block?
            Teams.find {block: this.block}
        else
            Teams.find()
)
