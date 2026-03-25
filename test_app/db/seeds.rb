# Pages (Scenario D: read-only, write guards)
Page.create!(name: "About Us", system: true, rich_content: RichContent.create!(markdown: "# About Us\n\nWe are a workshop company."))
Page.create!(name: "FAQ", rich_content: RichContent.create!(markdown: "# FAQ\n\nFrequently asked questions."))

# Workshops (Scenario B: inline blocks, nested)
cooking = Workshop.create!(
  title: "Italian Pasta Making",
  slug: "italian-pasta",
  category: "cooking",
  status: "published",
  start_date: 2.weeks.from_now.to_date,
  end_date: 2.weeks.from_now.to_date,
  max_capacity: 12,
  description: RichContent.create!(markdown: "Learn to make fresh pasta from scratch."),
  pricing_info: RichContent.create!(markdown: "$75 per person, includes all materials.")
)
cooking.materials.create!([
  {name: "Flour (00)", quantity: 5, unit_cost: 3.50},
  {name: "Eggs (dozen)", quantity: 2, unit_cost: 4.00},
  {name: "Olive Oil", quantity: 1, unit_cost: 8.00}
])

art = Workshop.create!(
  title: "Watercolour Landscapes",
  slug: "watercolour-landscapes",
  category: "art",
  status: "draft",
  start_date: 1.month.from_now.to_date,
  end_date: (1.month.from_now + 1.day).to_date,
  max_capacity: 8,
  description: RichContent.create!(markdown: "Explore watercolour techniques for landscape painting."),
  pricing_info: RichContent.create!(markdown: "$120 per person, 2-day workshop.")
)
art.materials.create!([
  {name: "Watercolour Set", quantity: 8, unit_cost: 15.00},
  {name: "Paper Pad", quantity: 8, unit_cost: 7.50}
])

# Registration with attendees (Scenarios C, D)
reg = Registration.create!(
  workshop: cooking,
  first_name: "Alice",
  last_name: "Johnson",
  email: "alice@example.com",
  phone: "555-0101",
  status: "confirmed"
)
reg.attendees.create!([
  {first_name: "Alice", last_name: "Johnson", email: "alice@example.com", phone: "555-0101", dietary_requirements: "Vegetarian", sort_order: 0},
  {first_name: "Bob", last_name: "Johnson", email: "bob@example.com", phone: "555-0102", dietary_requirements: "None", age: 14, sort_order: 1}
])

reg2 = Registration.create!(
  workshop: cooking,
  first_name: "Carol",
  last_name: "Smith",
  email: "carol@example.com",
  phone: "555-0201",
  status: "pending"
)
reg2.attendees.create!(first_name: "Carol", last_name: "Smith", email: "carol@example.com", sort_order: 0)
