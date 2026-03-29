# AGENTS.md

## Project overview
This repo is a Ruby on Rails 7 application for managing tools tied to authenticated users.

Current stack in this codebase:
- Ruby 3.1.3
- Rails 7.0.4
- PostgreSQL via `pg`
- Devise for authentication
- Importmap, Turbo, and Stimulus
- ERB views plus Jbuilder JSON views
- Minitest (`test/`), not RSpec
- RuboCop

## Repo shape
Key areas to inspect before changing behavior:
- `app/controllers/tools_controller.rb` is the main resource controller
- `app/models/tool.rb` and `app/models/user.rb` hold the core domain logic
- `app/views/tools/` contains the main HTML and JSON responses
- `app/views/devise/` contains customized auth views
- `config/routes.rb` contains the app flow and some duplicated `tools` route declarations
- `test/` contains controller, model, and system tests

There are also legacy scaffold leftovers for `Friend` resources in `test/fixtures` and some `test/` files. Treat them as existing repo baggage unless the task is explicitly about cleaning them up.

## Architecture and conventions
Prefer standard Rails conventions and small, targeted changes.

For this repo specifically:
- Keep business logic close to `Tool` and `User` unless a new abstraction clearly improves readability
- Keep `ToolsController` focused on request flow, filtering, and response handling
- Prefer server-rendered ERB views and existing partial patterns in `app/views/tools/`
- Preserve Devise-driven authentication flows and `current_user` ownership patterns
- Reuse Jbuilder templates when changing JSON responses instead of inventing parallel serializers

## Implementation rules
When making changes:
1. Read the relevant model, controller, view, route, and test files in that feature area first
2. Match the existing Rails style in that part of the app before introducing new patterns
3. Prefer fixing the narrow behavior requested over broad cleanup
4. If you encounter obvious legacy inconsistencies, note them, but do not refactor unrelated areas unless asked
5. Keep controller actions readable and move reusable logic into models/helpers only when it genuinely simplifies the code
6. Prefer Rails forms, partials, and path helpers over custom plumbing
7. Keep HTML responses and JSON responses in sync when both are supported
8. Make sure any user-specific data stays scoped correctly to the signed-in user or admin flow already present

## Authentication and authorization
- Use Devise helpers such as `authenticate_user!`, `user_signed_in?`, and `current_user`
- Do not bypass the existing ownership relationship between `User` and `Tool`
- Be careful when modifying public actions in `ToolsController`, because some actions are intentionally exposed while others rely on authentication
- If authorization behavior is unclear, preserve current behavior and call out the ambiguity instead of guessing

## Database and models
- PostgreSQL is the source of truth
- Prefer Active Record queries and scopes over raw SQL unless there is a clear need
- Keep migrations reversible and minimal
- Avoid changing schema or callbacks unless the task requires it
- When touching `Tool`, watch the date-related behavior around `date_of_use`, `date_due_to`, and ownership via `belongs_to :user`

## Views and frontend
- Most UI is traditional ERB rendered on the server
- Favor small partials and straightforward helpers over view-heavy abstractions
- Keep forms and tables usable on desktop and mobile
- Use Turbo or Stimulus only when the repo already benefits from it in that area; do not force a JS solution for simple server-rendered flows
- Preserve the existing mix of English and Spanish UI copy unless the task includes copy cleanup

## Testing
This repo uses Minitest.

When changing behavior:
- Add or update tests under `test/`, not `spec/`
- Prefer the narrowest useful test level: model, controller/integration, or system
- Do not extend the old `Friend` scaffold tests unless you are intentionally working on that legacy area
- Keep fixtures and assertions simple and readable

## Style
- Follow RuboCop and idiomatic Ruby
- Favor explicit, readable code over cleverness
- Keep methods reasonably small
- Avoid introducing new framework-like abstractions
- Leave comments only when they help explain non-obvious behavior

## What to avoid
Avoid introducing:
- RSpec-only guidance or `spec/`-based workflows
- New gems when Rails already provides a simple solution
- Large service-object layers for straightforward CRUD behavior
- Unrelated cleanup of legacy `Friend` remnants during a feature change
- Duplicate route/controller/view patterns when an existing `tools` pattern can be reused

## Preferred workflow
Before implementing:
- read the relevant files in `app/`, `config/routes.rb`, and matching tests in `test/`
- check whether the feature already has both HTML and JSON response paths
- note any legacy inconsistencies that could affect the requested change

When implementing:
- make the smallest coherent change
- preserve existing behavior unless the task is explicitly changing it
- align with current Devise and `current_user` usage

Before finishing:
- run the relevant Minitest files when possible
- run RuboCop on changed files when possible
- sanity-check routes, forms, and any date/update flows you touched

## Useful commands
- `bin/rails test`
- `bin/rails test test/models`
- `bin/rails test test/controllers`
- `bin/rails test test/system`
- `bin/rails routes`
- `bundle exec rubocop`

## Output expectations
When proposing or making changes:
- explain briefly how the change fits the current Rails patterns in this repo
- mention legacy inconsistencies only when they affect the task
- keep diffs focused and easy to review
