# -*- coding: utf-8 -*-

from gluon import current
from s3 import *
from eden.layouts import *
try:
    from .layouts import *
except ImportError:
    pass
import eden.menus as default

# =============================================================================
class S3MainMenu(default.S3MainMenu):
    """
        Custom Application Main Menu:
    """

    # -------------------------------------------------------------------------
    @classmethod
    def menu(cls):
        """ Compose Menu """

        # Modules menus
        main_menu = MM()(
            cls.menu_modules(),
        )

        # Additional menus
        current.menu.top = cls.menu_auth()

        return main_menu

    # -------------------------------------------------------------------------
    @classmethod
    def menu_modules(cls):
        """ Custom Modules Menu """

        return [
            homepage("project", name=current.T("Projects"))(),
        ]

    # -------------------------------------------------------------------------
    @classmethod
    def menu_auth(cls, **attr):
        """ Custom Auth Menu """

        auth = current.auth
        logged_in = auth.is_logged_in()
        self_registration = current.deployment_settings.get_security_self_registration()

        if not logged_in:
            request = current.request
            login_next = URL(args=request.args, vars=request.vars)
            if request.controller == "default" and \
               request.function == "user" and \
               "_next" in request.get_vars:
                login_next = request.get_vars["_next"]

            menu_auth = MM("Login", c="default", f="user", m="login",
                           _id="auth_menu_login",
                           vars=dict(_next=login_next), **attr)(
                            MM("Login", m="login",
                               vars=dict(_next=login_next)),
                            MM("Register", m="register",
                               vars=dict(_next=login_next),
                               check=self_registration),
                            #MM("Lost Password", m="retrieve_password"),
                            MM("About", c="default", f="about"),
                            MM("User Manual", c="static", f="DRR_Portal_User_Manual.pdf"),
                            MM("Contact", url="mailto:admin@drrprojects.net"),
                        )
        else:
            # Logged-in
            menu_auth = MM(auth.user.email, c="default", f="user",
                           translate=False, link=False, _id="auth_menu_email",
                           **attr)(
                            MM("Logout", m="logout", _id="auth_menu_logout"),
                            MM("User Profile", m="profile"),
                            #MM("Personal Data", c="pr", f="person", m="update",
                            #    vars={"person.pe_id" : auth.user.pe_id}),
                            #MM("Contact Details", c="pr", f="person",
                            #    args="contact",
                            #    vars={"person.pe_id" : auth.user.pe_id}),
                            MM("Subscriptions", c="pr", f="person",
                                args="pe_subscription",
                                vars={"person.pe_id" : auth.user.pe_id}),
                            MM("Change Password", m="change_password"),
                        )

        return menu_auth

# END =========================================================================
