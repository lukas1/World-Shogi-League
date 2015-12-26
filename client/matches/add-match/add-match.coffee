selectedClass = new ReactiveVar("")

Template.addMatch.helpers
    selectedClass: ->
        selectedClass.get()

Template.addMatch.events
    "submit #new-match-form": (event) ->
        event.preventDefault()
        return false if not isAdmin()

        # Get values
        teamAId = $("#blockTeam").val()
        teamBId = $("#block" + selectedClass.get() + "Team").val()

        # validate
        return false if not teamAId?.length or not teamBId?.length
        if teamAId == teamBId
            alert "Select two different teams to play against each other!"
            return false

        matchEndDate = moment().add(8, 'days').toDate()

        matchId = Matches.insertMatch(
            teamAId: teamAId
            teamBId: teamBId
            class: selectedClass.get()
            createdAt: new Date()
            matchEndDate: matchEndDate
        )


        return false if not matchId

        # Clear form
        $("#blockATeam").prop('selectedIndex', 0);
        $("#blockBTeam").prop('selectedIndex', 0);

        # Prevent default form submit
        return false

    "change #blockTeam": (event) ->
        event.preventDefault()

        teamId = $("#blockTeam").val()
        team = Teams.findOne teamId
        selectedClass.set team?.class
