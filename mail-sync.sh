#!/usr/bin/env bash
cd ~/.mail/
gmi sync
notmuch tag -unread -- tag spam
