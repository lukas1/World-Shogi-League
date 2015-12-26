selectedClass = new ReactiveVar("")

Template.addMatch.helpers
    selectedClass: ->
        selectedClass.get()

Template.addMatch.rendered = ->
    selectedClass.set("")


Template.addMatch.events
    "submit #new-match-form": (event) ->
        event.preventDefault()
        return false if not isAdmin()

        # Get values
        teamAId = $("#classTeam").val()
        teamBId = $("#class" + selectedClass.get() + "Team").val()

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
        $("#classATeam").prop('selectedIndex', 0);
        $("#classBTeam").prop('selectedIndex', 0);

        # Prevent default form submit
        return false

    "change #classTeam": (event) ->
        event.preventDefault()

        teamId = $("#classTeam").val()
        team = Teams.findOne teamId
        selectedClass.set team?.class
