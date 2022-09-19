---
layout: page
title: Lecture Notes
description: Lecture Notes written by the TAs!
---

lecture notes!

{% for lecture in site.lectures %}

- [{{lecture.title}}]({{site.baseurl}}{{ lecture.url }})

{% endfor %}
