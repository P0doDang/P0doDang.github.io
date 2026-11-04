---
title: Categories
icon: fas fa-stream
order: 1
---

{% include lang.html %}

{% comment %} 항상 보여 줄 상위 카테고리 (글이 없어도 표시). 글에 쓰는 이름과 똑같이 적는다. {% endcomment %}
{% assign fixed = "개발|CTF/Wargame|Bug Bounty|블로그/기술문서|논문/컨퍼런스|공모전/자격증" | split: "|" %}

{% comment %} 고정 목록에 없는 상위 카테고리는 글이 생기면 자동으로 뒤에 추가 {% endcomment %}
{% assign top_names = fixed %}
{% assign sort_categories = site.categories | sort %}
{% for category in sort_categories %}
  {% assign cname = category | first %}
  {% assign cposts = category | last %}
  {% assign cfirst = cposts | first %}
  {% if cname == cfirst.categories[0] %}
    {% unless top_names contains cname %}
      {% assign top_names = top_names | push: cname %}
    {% endunless %}
  {% endif %}
{% endfor %}

{% for category_name in top_names %}
  {% assign posts_of_category = site.categories[category_name] %}
  {% assign top_posts_size = posts_of_category | size %}

  {% assign sub_categories = '' | split: '' %}
  {% for post in posts_of_category %}
    {% if post.categories[0] == category_name %}
      {% assign second_category = post.categories[1] %}
      {% if second_category %}
        {% unless sub_categories contains second_category %}
          {% assign sub_categories = sub_categories | push: second_category %}
        {% endunless %}
      {% endif %}
    {% endif %}
  {% endfor %}
  {% assign sub_categories = sub_categories | sort %}
  {% assign sub_categories_size = sub_categories | size %}

  <div class="card categories">
    <div class="card-header d-flex justify-content-between hide-border-bottom">
      <span class="ms-2">
        <i class="far fa-folder{% if sub_categories_size > 0 %}-open{% endif %} fa-fw"></i>

        {% if top_posts_size > 0 %}
          {% capture _category_url %}/categories/{{ category_name | slugify | url_encode }}/{% endcapture %}
          <a href="{{ _category_url | relative_url }}" class="mx-2">{{ category_name }}</a>
        {% else %}
          <span class="mx-2">{{ category_name }}</span>
        {% endif %}

        <span class="text-muted small font-weight-light">
          {% if sub_categories_size > 0 %}
            {{ sub_categories_size }}
            {% if sub_categories_size > 1 %}
              {{ site.data.locales[lang].categories.category_measure.plural | default: site.data.locales[lang].categories.category_measure }}
            {% else %}
              {{ site.data.locales[lang].categories.category_measure.singular | default: site.data.locales[lang].categories.category_measure }}
            {% endif -%}
            ,
          {% endif %}

          {{ top_posts_size }}
          {% if top_posts_size > 1 %}
            {{ site.data.locales[lang].categories.post_measure.plural | default: site.data.locales[lang].categories.post_measure }}
          {% else %}
            {{ site.data.locales[lang].categories.post_measure.singular | default: site.data.locales[lang].categories.post_measure }}
          {% endif %}
        </span>
      </span>
    </div>

    {% if sub_categories_size > 0 %}
      <div class="collapse show">
        <ul class="list-group">
          {% for sub_category in sub_categories %}
            <li class="list-group-item">
              <i class="far fa-folder fa-fw"></i>
              {% capture _sub_ctg_url %}/categories/{{ sub_category | slugify | url_encode }}/{% endcapture %}
              <a href="{{ _sub_ctg_url | relative_url }}" class="mx-2">{{ sub_category }}</a>
              {% assign posts_size = site.categories[sub_category] | size %}
              <span class="text-muted small font-weight-light">
                {{ posts_size }}
                {% if posts_size > 1 %}
                  {{ site.data.locales[lang].categories.post_measure.plural | default: site.data.locales[lang].categories.post_measure }}
                {% else %}
                  {{ site.data.locales[lang].categories.post_measure.singular | default: site.data.locales[lang].categories.post_measure }}
                {% endif %}
              </span>
            </li>
          {% endfor %}
        </ul>
      </div>
    {% endif %}
  </div>
{% endfor %}