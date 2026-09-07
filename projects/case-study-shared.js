(function () {
  "use strict";

  var root = document.documentElement;
  root.classList.add("js");

  var reduced = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var hasObserver = "IntersectionObserver" in window;

  function addClass(el, name) {
    if (el) el.classList.add(name);
  }

  function revealAll() {
    document.querySelectorAll("[data-reveal]").forEach(function (el) {
      el.classList.add("is-visible");
    });
  }

  if (reduced || !hasObserver) {
    revealAll();
  } else {
    var revealObserver = new IntersectionObserver(function (entries, observer) {
      entries.forEach(function (entry, index) {
        if (!entry.isIntersecting) return;
        window.setTimeout(function () {
          entry.target.classList.add("is-visible");
        }, Math.min(index * 95, 360));
        observer.unobserve(entry.target);
      });
    }, { threshold: 0.08, rootMargin: "0px 0px -8% 0px" });
    document.querySelectorAll("[data-reveal]").forEach(function (el) {
      revealObserver.observe(el);
    });
  }

  function setPressed(buttons, current) {
    buttons.forEach(function (button) {
      button.setAttribute("aria-pressed", String(button === current));
    });
  }

  function replay(el, className) {
    if (!el || reduced) return;
    el.classList.remove(className);
    void el.offsetWidth;
    el.classList.add(className);
  }

  function watchSequence(container, selector, className, delay, threshold) {
    if (!container) return;
    var items = Array.prototype.slice.call(container.querySelectorAll(selector));
    function play() {
      items.forEach(function (item, index) {
        window.setTimeout(function () { item.classList.add(className); }, reduced ? 0 : index * delay);
      });
    }
    if (reduced || !hasObserver) {
      play();
      return;
    }
    var observer = new IntersectionObserver(function (entries, obs) {
      if (!entries.some(function (entry) { return entry.isIntersecting; })) return;
      play();
      obs.disconnect();
    }, { threshold: threshold || 0.28 });
    observer.observe(container);
  }

  function watchOnce(element, callback, threshold) {
    if (!element) return;
    if (reduced || !hasObserver) {
      callback();
      return;
    }
    var observer = new IntersectionObserver(function (entries, obs) {
      if (!entries.some(function (entry) { return entry.isIntersecting; })) return;
      callback();
      obs.disconnect();
    }, { threshold: threshold || 0.28 });
    observer.observe(element);
  }

  // The navigation compresses as the page becomes a case-reading surface.
  var nav = document.querySelector(".case-nav");
  if (nav) {
    var updateNav = function () { nav.classList.toggle("scrolled", window.scrollY > 56); };
    updateNav();
    window.addEventListener("scroll", updateNav, { passive: true });
  }

  // A small cursor echo keeps the desktop pages in the same visual family as the existing cases.
  if (!reduced && window.matchMedia && window.matchMedia("(pointer: fine)").matches) {
    var cursor = document.createElement("div");
    var cursorRing = document.createElement("div");
    cursor.className = "case-cursor";
    cursorRing.className = "case-cursor-ring";
    cursor.setAttribute("aria-hidden", "true");
    cursorRing.setAttribute("aria-hidden", "true");
    document.body.appendChild(cursor);
    document.body.appendChild(cursorRing);
    document.body.classList.add("has-case-cursor");
    document.addEventListener("pointermove", function (event) {
      cursor.style.transform = "translate(" + event.clientX + "px," + event.clientY + "px) translate(-50%,-50%)";
      cursorRing.style.transform = "translate(" + event.clientX + "px," + event.clientY + "px) translate(-50%,-50%)";
    }, { passive: true });
    document.querySelectorAll("a, button, .pill, .rule-item, .numbered-row, .path-step, .role-item").forEach(function (el) {
      el.addEventListener("pointerenter", function () { cursorRing.classList.add("is-large"); });
      el.addEventListener("pointerleave", function () { cursorRing.classList.remove("is-large"); });
    });
  }

  // A-pillar view model: the text, signal state, and highlighted zone change as one motion event.
  var viewCopy = {
    left: {
      title: "左侧视图",
      body: "当左侧区域需要补盲信息时，对应视图获得清晰反馈，帮助驾驶者理解当前显示内容。",
      status: "LEFT SIGNAL ACTIVE"
    },
    right: {
      title: "右侧视图",
      body: "当右侧区域需要补盲信息时，视图与提示保持对应，避免左右信息错位。",
      status: "RIGHT SIGNAL ACTIVE"
    },
    exit: {
      title: "退出显示",
      body: "相关条件结束或能力不可用时，影像按规则退出，座舱回到合理的显示状态。",
      status: "VIEW CLEARED / STANDBY"
    }
  };
  var viewButtons = Array.prototype.slice.call(document.querySelectorAll("[data-view]"));
  var viewTitle = document.querySelector("[data-view-title]");
  var viewBody = document.querySelector("[data-view-body]");
  var viewStatus = document.querySelector("[data-view-status]");
  var viewDemo = document.querySelector(".view-demo");
  var cockpit = document.querySelector(".cockpit");
  var screenZones = Array.prototype.slice.call(document.querySelectorAll("[data-screen-zone]"));
  viewButtons.forEach(function (button) {
    button.addEventListener("click", function () {
      var key = button.getAttribute("data-view");
      var content = viewCopy[key];
      if (!content) return;
      setPressed(viewButtons, button);
      [viewTitle, viewBody, viewStatus].forEach(function (el) { replay(el, "is-changing"); });
      window.setTimeout(function () {
        if (viewTitle) viewTitle.textContent = content.title;
        if (viewBody) viewBody.textContent = content.body;
        if (viewStatus) viewStatus.textContent = content.status;
      }, reduced ? 0 : 90);
      if (viewDemo) viewDemo.setAttribute("data-view-state", key);
      if (cockpit) cockpit.classList.toggle("is-clear", key === "exit");
      screenZones.forEach(function (zone) {
        zone.classList.toggle("active", zone.getAttribute("data-screen-zone") === key);
        replay(zone, "is-switching");
      });
    });
  });

  // The rule list and the input-to-output diagram resolve one item at a time.
  watchSequence(document.querySelector('[data-motion-list="rules"]'), "[data-motion-row]", "is-live", 170, 0.24);
  watchSequence(document.querySelector("[data-flow-track]"), "[data-flow-node], [data-flow-arrow]", "is-live", 180, 0.3);

  // Weight system: the question ladder and information model use state changes instead of static cards.
  watchSequence(document.querySelector("[data-question-ladder]"), "[data-question-step]", "is-active", 180, 0.25);
  watchSequence(document.querySelector("[data-meaning-list]"), "[data-meaning-item]", "is-live", 150, 0.25);
  watchSequence(document.querySelector("[data-path-pair]"), "[data-path-step]", "is-live", 120, 0.25);
  watchSequence(document.querySelector("[data-roles]"), "[data-role-item]", "is-live", 150, 0.25);
  watchOnce(document.querySelector("[data-reframe]"), function () {
    addClass(document.querySelector("[data-reframe]"), "is-live");
  }, 0.3);

  var dataCopy = {
    feeding: {
      title: "累计进食",
      body: "今日记录承接宠物当天的进食统计，让用户先看过程，再理解当前状态。",
      caption: "today / feeding",
      state: "TRACKING / TODAY",
      rows: [["累计进食克重", "按记录汇总"], ["查看事件", "可筛选"], ["关联计划", "继续执行"]]
    },
    output: {
      title: "喂食执行",
      body: "累计出粮反映设备实际执行情况，计划完成情况与进食信息保持语义区分。",
      caption: "today / output",
      state: "EXECUTING / PLAN",
      rows: [["累计出粮", "显示份数"], ["每份克重", "当前样本"], ["剩余计划", "待执行"]]
    },
    remainder: {
      title: "当前余粮",
      body: "余粮保留为独立状态信息，展示当前量、状态和更新时间，帮助用户补充判断。",
      caption: "now / remainder",
      state: "MONITORING / NOW",
      rows: [["余粮状态", "充足 / 不足"], ["当前克重", "传感器读数"], ["更新时间", "最近一次"]]
    }
  };
  var dataButtons = Array.prototype.slice.call(document.querySelectorAll("[data-data-view]"));
  var dataTitles = Array.prototype.slice.call(document.querySelectorAll("[data-data-title]"));
  var dataBody = document.querySelector("[data-data-body]");
  var dataCaption = document.querySelector("[data-data-caption]");
  var dataState = document.querySelector("[data-data-state]");
  var dataPanel = document.querySelector(".data-panel");
  var dataCopyBlock = document.querySelector(".data-copy");
  var dataRows = Array.prototype.slice.call(document.querySelectorAll("[data-data-row]"));
  dataButtons.forEach(function (button) {
    button.addEventListener("click", function () {
      var key = button.getAttribute("data-data-view");
      var content = dataCopy[key];
      if (!content) return;
      setPressed(dataButtons, button);
      replay(dataPanel, "is-swapping");
      replay(dataCopyBlock, "is-swapping");
      dataTitles.forEach(function (title) { title.textContent = content.title; });
      if (dataBody) dataBody.textContent = content.body;
      if (dataCaption) dataCaption.textContent = content.caption;
      if (dataState) dataState.textContent = content.state;
      dataRows.forEach(function (row, index) {
        var values = content.rows[index];
        if (!values) return;
        row.classList.toggle("selected", index === 0);
        row.querySelector("[data-row-label]").textContent = values[0];
        row.querySelector("[data-row-value]").textContent = values[1];
        replay(row, "is-row-changing");
      });
    });
  });

  // Animate the factual feedback metric from zero to the displayed result.
  var counters = Array.prototype.slice.call(document.querySelectorAll("[data-counter]"));
  function finishCounter(el) {
    var target = Number(el.getAttribute("data-target")) || 0;
    var decimals = Number(el.getAttribute("data-decimals")) || 0;
    el.textContent = target.toFixed(decimals);
  }
  function animateCounter(el) {
    if (reduced) {
      finishCounter(el);
      return;
    }
    var target = Number(el.getAttribute("data-target")) || 0;
    var decimals = Number(el.getAttribute("data-decimals")) || 0;
    var start = performance.now();
    var duration = 1450;
    function tick(now) {
      var progress = Math.min((now - start) / duration, 1);
      var eased = 1 - Math.pow(1 - progress, 3);
      el.textContent = (target * eased).toFixed(decimals);
      if (progress < 1) window.requestAnimationFrame(tick);
    }
    window.requestAnimationFrame(tick);
  }
  if (counters.length) {
    var counterTarget = document.querySelector(".metric-result");
    watchOnce(counterTarget, function () {
      addClass(counterTarget, "is-live");
      counters.forEach(animateCounter);
    }, 0.35);
  }
}());
