@Routes =
    home:
        path: '/'
        template: 'home'
        name: 'home'
    oops:
        template: 'oops'
    login:
        path: '/user/login',
        template: 'loginform'
        name: 'user.login'
    registration:
        path: '/user/registration',
        template: 'registration'
        name: 'user.registration'
    teamsEdit:
        path: '/teams/edit'
        template: 'teamsedit'
        name: 'teams.edit'
    userList:
        path: '/user/list'
        template: 'userlist'
        name: 'user.list'
    updateUser:
        path: '/user/update'
        template: 'updateuser'
        name: 'user.update'
    scheduleMatch:
        path: '/matches/schedule'
        template: 'scheduleMatch'
        name: 'matches.schedule'
