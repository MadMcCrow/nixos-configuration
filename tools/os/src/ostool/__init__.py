#!/usr/bin/env python3
"""
OS tool entry point
"""

from .app import App

if __name__ == "__main__":
    app = App()
    app.cli()
