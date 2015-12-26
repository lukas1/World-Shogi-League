Template.teamsedit.helpers(
    teams: () ->
        Teams.find {}, { sort: { class: 1, name: 1 } }
)

Template.teamsedit.events
    "click .teamBaseRow": (event, template) ->
        Template.teamupdate.closeAllInstances()

        # Get Team Id
        teamBaseRow = $(event.target).closest('.teamBaseRow')
        teamId = $(event.target).closest('.teamBaseRow').attr('id')
        teamId = teamId.replace 'team_', ''

        teamData = Teams.findOne(teamId);

        # Create new line
        Blaze.renderWithData Template.teamupdate, teamData,
            $(teamBaseRow).closest('table').get(0), $(teamBaseRow).next().get(0)

    "click .delete": (event, template) ->
        event.stopPropagation()
        return false if not Meteor.userId()?
        teamId = $(event.target).attr('teamid')
        if teamId.length > 0
            if confirm "Do you really want to remove this team?
                All it's matches will be lost"
                Teams.removeTeam teamId

    "submit #new-team-form": (event, template) ->
        event.preventDefault();
        return false if not isAdmin()

        teamName = template.$('#addTeamName').val()
        teamClass = template.$('#addTeamClass').val()
        return false if teamName.length == 0 or teamClass.length == 0

        Teams.insert {name: teamName, class: teamClass, points: 0}

        # reset input field
        template.$('#addTeamName').val('')
        template.$('#addTeamClass').prop('selectedIndex', 0)

        return false;
