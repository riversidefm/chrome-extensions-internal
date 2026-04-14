const toggle = document.getElementById('toggle');
const status = document.getElementById('status');

function updateUI(enabled) {
  toggle.checked = enabled;
  if (enabled) {
    status.textContent = 'Active — header injected on all requests';
    status.className = 'status on';
  } else {
    status.textContent = 'Inactive — header injection disabled';
    status.className = 'status off';
  }
}

chrome.storage.local.get({ enabled: true }, ({ enabled }) => {
  updateUI(enabled);
});

toggle.addEventListener('change', () => {
  const enabled = toggle.checked;

  chrome.declarativeNetRequest.updateEnabledRulesets(
    enabled
      ? { enableRulesetIds: ['ruleset_1'], disableRulesetIds: [] }
      : { enableRulesetIds: [], disableRulesetIds: ['ruleset_1'] },
    () => {
      chrome.storage.local.set({ enabled });
      updateUI(enabled);
    }
  );
});
