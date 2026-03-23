#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for file in action.yml README.md LICENSE .gitignore; do
  if [[ ! -f "${ROOT_DIR}/${file}" ]]; then
    echo "Missing required file: ${file}" >&2
    exit 1
  fi
done

ruby - "${ROOT_DIR}" <<'RUBY'
require "yaml"

root = ARGV.fetch(0)
action = YAML.load_file(File.join(root, "action.yml"))

abort("Expected composite action") unless action.dig("runs", "using") == "composite"

required_inputs = %w[
  unity-version
  target-platform
  build-metrics-api-key
]

required_inputs.each do |name|
  input = action.fetch("inputs").fetch(name)
  abort("Input #{name} must be required") unless input["required"] == true
end

optional_defaults = {
  "project-path" => ".",
  "builds-path" => "build",
  "allow-dirty-git" => "false"
}

optional_defaults.each do |name, expected|
  actual = action.fetch("inputs").fetch(name)["default"]
  abort("Input #{name} default mismatch: #{actual.inspect}") unless actual == expected
end

required_outputs = %w[build-version output-path artifact-path]
required_outputs.each do |name|
  abort("Missing output #{name}") unless action.fetch("outputs").key?(name)
end

abort("Expected Marketplace branding") unless action.key?("branding")
RUBY

for example in "${ROOT_DIR}"/examples/*.yml; do
  if ! grep -q "Alexartx/unity-build-metrics-action@v1" "${example}"; then
    echo "Example does not reference published action: ${example}" >&2
    exit 1
  fi
done

for token in "one reusable step" "Troubleshooting" "Build Metrics plugin docs"; do
  if ! grep -q "${token}" "${ROOT_DIR}/README.md"; then
    echo "README missing expected section marker: ${token}" >&2
    exit 1
  fi
done

echo "unity-build-metrics-action validation passed"
