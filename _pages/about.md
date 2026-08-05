---
permalink: /
title: "Home"
description: "Yu Zheng is a master's student at Hunan University working on computer vision, robotics, embodied AI, and world models."
author_profile: true
hide_title: true
redirect_from: 
  - /about/
  - /about.html
---

{% assign profile = site.data.profile %}

<section class="profile-hero">
  <p class="profile-eyebrow">Hunan University · AI and Robotics</p>
  <h1>Yu Zheng <span>郑誉</span></h1>
  <p class="profile-lede">I am a master's student in Electronic Information at the School of Artificial Intelligence and Robotics, Hunan University. I work on computer vision, representation learning, robotics, and embodied AI, co-advised by <a href="https://jamycheung.github.io/">Prof. Jiaming Zhang</a> and <a href="https://yangkailun.com/">Prof. Kailun Yang</a>.</p>
  <div class="profile-actions">
    <a class="btn btn--primary" href="/publications/">Publications</a>
    <a class="btn btn--inverse" href="/projects/">Projects</a>
    <a class="btn btn--inverse" href="mailto:defateyz@gmail.com">Email</a>
  </div>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Research</h2>
  <ul class="profile-focus-list" aria-label="Research interests">
    {% for interest in profile.research_interests %}
      <li>{{ interest }}</li>
    {% endfor %}
  </ul>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Publications</h2>
  <div class="profile-publication-list">
    {% for publication in profile.publications %}
      {% include profile-publication-card.html publication=publication heading="h3" hide_description=true compact=true %}
    {% endfor %}
  </div>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Education</h2>
  <ol class="profile-timeline">
    {% for item in profile.education %}
      <li>
        <span>{{ item.period }}</span>
        <strong>{{ item.title }}</strong>
        <p>{{ item.detail }}</p>
      </li>
    {% endfor %}
  </ol>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Professional Activities</h2>
  {% assign activity = profile.professional_activities %}
  <ul class="profile-record-list" aria-label="{{ activity.title }}">
    {% for item in activity.items %}
      <li>{{ item | markdownify | remove: '<p>' | remove: '</p>' }}</li>
    {% endfor %}
  </ul>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Internship</h2>
  {% assign internship = profile.internships %}
  <ul class="profile-record-list" aria-label="{{ internship.title }}">
    {% for item in internship.items %}
      <li>{{ item | markdownify | remove: '<p>' | remove: '</p>' }}</li>
    {% endfor %}
  </ul>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Projects</h2>
  {% assign project_group = profile.projects_and_patents %}
  <ul class="profile-record-list" aria-label="{{ project_group.title }}">
    {% for item in project_group.items %}
      <li>{{ item | markdownify | remove: '<p>' | remove: '</p>' }}</li>
    {% endfor %}
  </ul>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Awards</h2>
  <div class="profile-award-list">
    {% for award in profile.awards %}
      <div class="profile-award-item">
        <span class="profile-award-year">{{ award.year }}</span>
        <div class="profile-award-title">
          <strong>{{ award.title }}</strong>
          <p>{{ award.detail }}</p>
        </div>
        <span class="profile-award-rank">{{ award.rank }}</span>
      </div>
    {% endfor %}
  </div>
</section>
