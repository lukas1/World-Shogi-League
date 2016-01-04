Template.classPoints.helpers
    teams: () ->
        Teams.find { class: Template.instance().data.class },
            { sort: { points: -1, name: 1 } }
