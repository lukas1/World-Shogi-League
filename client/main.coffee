Router.configure({
    layoutTemplate:"applicationLayout"
})

Router.route(Routes.home.path, () ->
    this.render(Routes.home.template);
)

Router.route(Routes.login.path, () ->
    this.render(Routes.login.template);
)

Router.route(Routes.teamsEdit.path, () ->
    this.render(Routes.teamsEdit.template);
)
