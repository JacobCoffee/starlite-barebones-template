# -*- coding: utf-8 -*-
"""Basic application for Starlite ASGI Framework"""
from pathlib import Path
from typing import Dict

from starlite import MediaType, Starlite, StaticFilesConfig, Template, TemplateConfig, get
from starlite.contrib.jinja import JinjaTemplateEngine


@get(
    path="/",
    media_type=MediaType.HTML,
    cache=False,
    tags=["Index"],
    include_in_schema=False,
    opt={"exclude_from_auth": True},
    name="index",
)
async def index() -> Template:
    """The index page using Jinja2 template engine.

    The templates are located in the templates directory.
    Context variables are passed to the template.
    """
    return Template(
        name="index.html",
        context={"title": "Home"},
    )


@get(name="ping", path="/ping", tags=["Ping"])
def ping_pong() -> Dict[str, str]:
    """A simple test world endpoint."""
    return {"ping": "pong"}


app = Starlite(
    route_handlers=[
        index,
        ping_pong,
    ],
    template_config=TemplateConfig(
        directory=Path(__file__).parent / "templates",
        engine=JinjaTemplateEngine,
    ),
    static_files_config=[
        StaticFilesConfig(directories=[Path(__file__).parent / "static"], path="static", name="static_files"),
        StaticFilesConfig(
            directories=[Path(__file__).parent.parent / "docs"], path="/docs", html_mode=True, name="docs"
        ),
    ],
    debug=True,
)
