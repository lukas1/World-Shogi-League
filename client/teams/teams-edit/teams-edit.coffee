Template.teamsedit.helpers(
    teams: () ->
        Teams.find {}
)

Template.teamsedit.events
    "click .delete": (event, template) ->
        teamId = $(event.target).attr('teamid')
        if teamId.length > 0
            if confirm "Do you really want to remove this team?
                All it's matches will be lost"
                Teams.removeTeam teamId
    "submit #new-team-form": (event, template) ->
        event.preventDefault();

        teamName = template.$('#addTeamName').val()
        return false if teamName.length == 0

        Teams.insert {name: teamName}

        # reset input field
        template.$('#addTeamName').val('')

        return false;
