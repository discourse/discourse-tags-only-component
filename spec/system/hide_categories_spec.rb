# frozen_string_literal: true

# This component is CSS-only: it hides category UI across the app with
# `display: none` rather than changing any behavior. These system specs
# therefore assert that the relevant elements are still rendered in the DOM
# (so we know the test set up real category content) but are NOT visible,
# and that the deliberate exemption (the categories page) keeps showing them.
#
# `visible: :hidden` matches an element only when it exists but is not visible
# (it or an ancestor is `display: none`) — exactly the behavior this component
# produces. Pairing an existence check (`visible: :all`) with a not-visible
# check guards against the test passing vacuously when an element simply
# isn't rendered.
RSpec.describe "Tags Only - hiding categories" do
  before { upload_theme_component }

  fab!(:category) { Fabricate(:category, name: "Announcements") }
  fab!(:tag) { Fabricate(:tag, name: "release") }
  fab!(:topic) { Fabricate(:topic, category: category, tags: [tag]) }
  fab!(:post) { Fabricate(:post, topic: topic) }

  before { SiteSetting.tagging_enabled = true }

  context "in topic lists" do
    it "renders the category badge but keeps it hidden" do
      visit("/latest")

      expect(page).to have_css(".topic-list-item", wait: 5)
      # Present in the DOM...
      expect(page).to have_css(".badge-category__wrapper", visible: :all)
      # ...but not visible.
      expect(page).to have_no_css(".badge-category__wrapper")
    end
  end

  context "when on the categories page (exempted)" do
    it "still shows category badges" do
      visit("/categories")

      expect(page).to have_css("body.categories-list")
      expect(page).to have_css(".badge-category__wrapper")
    end
  end

  context "in the navigation menu" do
    fab!(:user)
    before { sign_in(user) }

    it "hides the categories section in the sidebar" do
      SiteSetting.navigation_menu = "sidebar"
      visit("/latest")

      expect(page).to have_css("#d-sidebar", wait: 5)
      # The section is rendered but hidden.
      expect(page).to have_css("[data-section-name='categories']", visible: :hidden)
      expect(page).to have_no_css("[data-section-name='categories']")
    end
  end

  context "in the composer" do
    # The category input is only hidden when the composer offers BOTH a
    # category chooser and tags (the `.with-tags.with-category` state), so the
    # user needs tagging permission — an admin always has it.
    fab!(:admin)
    before { sign_in(admin) }

    it "hides the category input in favor of tags" do
      visit("/new-topic")

      expect(page).to have_css("#reply-control .reply-area.with-tags.with-category", wait: 5)
      # The category chooser is rendered but hidden.
      expect(page).to have_css(".category-input", visible: :all)
      expect(page).to have_no_css(".category-input")
    end
  end
end
