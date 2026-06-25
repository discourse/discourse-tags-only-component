# frozen_string_literal: true

# Parts of the core features examples can be skipped like so:
#   it_behaves_like "having working core features", skip_examples: %i[login likes]
#
# List of keywords for skipping examples:
# login, likes, profile, topics, topics:read, topics:reply, topics:create,
# search, search:quick_search, search:full_page
#
# For more details, see https://meta.discourse.org/t/-/361381
RSpec.describe "Core features" do
  before { upload_theme_or_component }

  # The "topics:read" examples include "lists topics for a category", which
  # navigates by clicking a category in the sidebar categories section. This
  # component deliberately hides that section (`[data-section-name="categories"]
  # { display: none; }`), so Capybara can't click the now-invisible link. The
  # skip keyword is group-level granularity, so this also opts out of the
  # sibling "lists latest topics"/"displays a specific topic" reads.
  it_behaves_like "having working core features", skip_examples: %i[topics:read]
end
