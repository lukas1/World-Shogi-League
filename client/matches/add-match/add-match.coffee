dateTimeFormat = 'DD/MM/YYYY HH:mm'

Template.addMatch.onRendered  ->
    this.$('#tournamentEndDate').datetimepicker
        useCurrent: false
        allowInputToggle: true
        sideBySide: true
        showClear: true
        format: dateTimeFormat
        minDate: new Date()
        defaultDate: moment().add(8, 'days')

Template.addMatch.events
    "submit #new-match-form": (event) ->
        event.preventDefault()
        return false if not isAdmin()

        # Get values
        teamAId = $("#blockATeam").val()
        teamBId = $("#blockBTeam").val()
        matchEndDateVal = $('#tournamentEndDate').find('input').val()
        matchEndDate = moment(matchEndDateVal, dateTimeFormat).toDate()

        # validate
        return false if not teamAId?.length or not teamBId?.length or not
        matchEndDateVal?.length or not matchEndDate?

        matchId = Matches.insertMatch(
            teamAId: teamAId,
            teamBId: teamBId,
            createdAt: new Date()
            matchEndDate: matchEndDate
        )


        return false if not matchId

        # Clear form
        $("#blockATeam").prop('selectedIndex', 0);
        $("#blockBTeam").prop('selectedIndex', 0);

        # Prevent default form submit
        return false
