---
layout: single
title: "CV"
description: "Curriculum vitae of Yu Zheng."
permalink: /cv/
author_profile: true
profile_layout: true
hide_title: true
redirect_from:
  - /resume
---

<section class="profile-page-heading">
  <p class="profile-kicker">Curriculum Vitae</p>
  <h1>Yu Zheng</h1>
  <p>Master's student in Electronic Information at Hunan University, working on computer vision, robotics, embodied AI, and world models.</p>
</section>

## Education

- **2025 - Now** · M.S. in Electronic Information, Hunan University, China
- **2021 - 2025** · B.S. in Software Engineering, South China Normal University, China
- **2021 - 2025** · B.S. in Computing Science, University of Aberdeen, United Kingdom

## Publications

{% assign publications = site.data.profile.publications | where_exp: "publication", "publication.hidden != true" | sort: 'sort_month' | reverse %}
{% for publication in publications %}
- **{{ publication.venue }}** · {{ publication.title }}. {% for link in publication.links %}[[{{ link.label | downcase }}]]({{ link.url }}) {% endfor %}
{% endfor %}

## Professional Activities

- Conference reviewer for ICLR and IROS.
- Journal reviewer for RAL.
- Workshop organizer, **Assistive Agents for All**, UbiComp 2026. [[website]](https://insailab.org/ubicomp2026-aaa-workshop/)

## Internship

- Research Intern, Dept. PAIR, PolyU, Hong Kong, China
- Interface Development Intern, Dept. TEG, Tencent, Shenzhen, China
- Assistant Tutor, Dept. RoboMaster, DJI, Shenzhen, China

## Projects

- **Sport Data Evaluation Technology Based on Human Pose Estimation and its Application** · China College Students Innovation and Entrepreneurship Project, provincial completed project, first author.

## Patents

- **2026 · Chinese Invention Patent · Grant Notice Issued** · *Intelligent Navigation Method, Apparatus, Equipment, and Medium for Agricultural Machinery*. Application No. 202610729267.7. Filed May 26, 2026; grant notice issued September 8, 2026; registration pending. Applicant: 杭州旷域智能科技有限公司.

- **2026 · Chinese Invention Patent · Granted** · *Coordinated Path and Height Planning System for a Height-Adjustable Wheeled-Legged Robot in Weeding*. Inventors: **Y. Zheng**, J. Gao. Patent No. ZL 2026 1 0943575.X; publication No. CN 122439517 B. Filed June 29, 2026; granted August 28, 2026. Assignee: 杭州旷域智能科技有限公司.

## Competitions

- 2024 RoboMaster University League Mech Master Competition Infantry Robot Award, National First Prize
- 2023 RoboMaster University League Mech Master Competition Infantry Combat Award, National Second Prize
- 2024 RoboMaster Super League Competition Infantry Robot Award, National Second Prize
- 2024 RoboMaster Super League Competition Overall Competition, National Third Prize
- 2023 MCM, Honorable Mention
- 2023 APMCM, Third Prize
- 2023 National Undergraduate Mathematical Contest in Modeling, Guangdong Provincial Second Prize
