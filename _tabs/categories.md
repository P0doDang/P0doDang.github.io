---
title: 카테고리
icon: fas fa-stream
order: 1
---

{% assign fixed = "개발|CTF/Wargame|Bug Bounty|블로그/기술문서|논문/컨퍼런스|공모전/자격증" | split: "|" %}

<ul>
{% for name in fixed %}
  {% assign posts = site.categories[name] %}
  {% assign count = posts | size %}
  <li>
    {% if count > 0 %}
      <a href="{{ name | slugify | url_encode | prepend: '/categories/' | append: '/' | relative_url }}">{{ name }}</a>
    {% else %}
      {{ name }}
    {% endif %}
    ({{ count }})
  </li>
{% endfor %}

{% for category in site.categories %}
  {% assign name = category[0] %}
  {% unless fixed contains name %}
  <li>
    <a href="{{ name | slugify | url_encode | prepend: '/categories/' | append: '/' | relative_url }}">{{ name }}</a>
    ({{ category[1] | size }})
  </li>
  {% endunless %}
{% endfor %}
</ul>