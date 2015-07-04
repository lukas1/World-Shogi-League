Template.teams.helpers(
    teams: () ->
        Teams.find {block: this.block}
)
