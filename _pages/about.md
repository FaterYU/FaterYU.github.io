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
  <p class="profile-eyebrow">Master student · Hunan University</p>
  <h1>Yu Zheng <span>郑誉</span></h1>
  <p class="profile-lede">I am a master's student in Electronic Information at the School of Artificial Intelligence and Robotics, Hunan University, co-advised by <a href="https://jamycheung.github.io/">Prof. Jiaming Zhang</a> and <a href="https://yangkailun.com/">Prof. Kailun Yang</a>. My research interests sit at the intersection of computer vision, representation learning, robotics, and embodied AI.</p>
  <div class="profile-actions">
    <a class="btn btn--primary" href="/publications/">Publications</a>
    <a class="btn btn--inverse" href="/projects/">Projects</a>
    <a class="btn btn--inverse" href="mailto:defateyz@gmail.com">Email</a>
  </div>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Research Interests</h2>
  <div class="profile-chip-grid" aria-label="Research interests">
    {% for interest in profile.research_interests %}
      <span>{{ interest }}</span>
    {% endfor %}
  </div>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Publications</h2>
  <div class="profile-publication-list">
    {% for publication in profile.publications limit: 3 %}
      {% include profile-publication-card.html publication=publication heading="h3" description=publication.description %}
    {% endfor %}
  </div>
  <p class="profile-more"><a href="/publications/">View all publications</a></p>
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
  <article class="profile-card">
    <p class="profile-card__meta">{{ activity.meta }}</p>
    <h3>{{ activity.title }}</h3>
    <ul>
      {% for item in activity.items %}
        <li>{{ item | markdownify | remove: '<p>' | remove: '</p>' }}</li>
      {% endfor %}
    </ul>
  </article>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Internship</h2>
  {% assign internship = profile.internships %}
  <article class="profile-card">
    <p class="profile-card__meta">{{ internship.meta }}</p>
    <h3>{{ internship.title }}</h3>
    <ul>
      {% for item in internship.items %}
        <li>{{ item | markdownify | remove: '<p>' | remove: '</p>' }}</li>
      {% endfor %}
    </ul>
  </article>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Projects and Patents</h2>
  {% assign project_group = profile.projects_and_patents %}
  <article class="profile-card">
    <p class="profile-card__meta">{{ project_group.meta }}</p>
    <h3>{{ project_group.title }}</h3>
    <ul>
      {% for item in project_group.items %}
        <li>{{ item | markdownify | remove: '<p>' | remove: '</p>' }}</li>
      {% endfor %}
    </ul>
  </article>
</section>

<section class="profile-section">
  <h2 class="profile-section-title">Awards</h2>
  <article class="profile-card profile-card--awards">
    <p class="profile-card__meta">Competitions and Honors</p>
    <h3>Selected awards</h3>
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
  </article>
</section>
