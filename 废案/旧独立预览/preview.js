(() => {
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const endpoint = window.PREVIEW_CHAT_ENDPOINT || "/api/chat";

  document.querySelectorAll(".route-segment").forEach((path) => {
    path.setAttribute("pathLength", "1");
  });

  const revealObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      entry.target.classList.add("is-visible");
      entry.target.querySelectorAll?.(".route-segment").forEach((path) => path.classList.add("is-visible"));
      observer.unobserve(entry.target);
    });
  }, { threshold: 0.12 });

  document.querySelectorAll(".section-block, .preview-bridge").forEach((element) => revealObserver.observe(element));

  const form = document.querySelector("[data-chat-form]");
  const input = document.querySelector("#chatInput");
  const messages = document.querySelector("[data-chat-messages]");
  const empty = document.querySelector("[data-chat-empty]");
  const status = document.querySelector("[data-chat-status]");
  const submit = form?.querySelector("button[type=submit]");

  const addMessage = (text, kind = "") => {
    const message = document.createElement("p");
    message.className = `chat-message ${kind}`.trim();
    message.textContent = text;
    messages?.appendChild(message);
    if (messages) messages.scrollTop = messages.scrollHeight;
    return message;
  };

  form?.addEventListener("submit", async (event) => {
    event.preventDefault();
    const message = input?.value.trim();
    if (!message || !submit || !messages) return;
    const preservedInput = message;
    empty?.remove();
    addMessage(message, "user");
    input.value = "";
    submit.disabled = true;
    if (status) status.textContent = "连接中…";
    const loading = addMessage("正在等待安全服务…", "loading");

    try {
      const response = await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json", Accept: "application/json" },
        body: JSON.stringify({ message })
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json();
      loading.remove();
      const reply = typeof data?.reply === "string" ? data.reply : (typeof data?.message === "string" ? data.message : "安全服务已返回，但没有可展示的消息。 ");
      addMessage(reply);
      if (status) status.textContent = "已连接";
    } catch (error) {
      loading.remove();
      addMessage("安全服务尚未连接，请稍后再试。", "error");
      input.value = preservedInput;
      if (status) status.textContent = "未连接";
    } finally {
      submit.disabled = false;
      input?.focus();
    }
  });

  if (reducedMotion) document.documentElement.classList.add("reduced-motion");
})();
