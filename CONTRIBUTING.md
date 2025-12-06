# Contributing to AWS SSM QuickSetup Terraform

First off, thank you for considering contributing to this project! 🎉

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Description**: Clear description of the bug
- **Steps to Reproduce**: Detailed steps to reproduce the behavior
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Environment**:
  - Terraform version (`terraform version`)
  - AWS Provider version
  - Operating System
- **Logs**: Relevant Terraform output or error messages

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Use case**: Why is this enhancement needed?
- **Proposed solution**: How would you implement it?
- **Alternatives**: Other approaches you've considered

### Pull Requests

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Test your changes**:
   ```bash
   terraform fmt -recursive
   terraform validate
   terraform plan -var-file=main.tfvars
   ```
5. **Commit** with a descriptive message:
   ```bash
   git commit -m "feat: add support for multiple regions"
   ```
6. **Push** to your fork:
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request** with:
   - Clear title and description
   - Reference to related issues
   - Screenshots (if applicable)

## Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Examples:
```
feat: add support for custom patch baselines
fix: correct IAM role trust policy
docs: update README with new examples
```

## Code Style

### Terraform

- Use **2 spaces** for indentation
- Run `terraform fmt` before committing
- Use meaningful variable and resource names
- Add comments for complex logic
- Group related resources in separate files

### Documentation

- Keep README.md up to date
- Document all variables in `variables.tf`
- Add examples for new features
- Update TROUBLESHOOTING.md for known issues

## Testing

Before submitting a PR:

1. **Format** your code:
   ```bash
   terraform fmt -recursive
   ```

2. **Validate** syntax:
   ```bash
   terraform validate
   ```

3. **Plan** to check for issues:
   ```bash
   terraform plan -var-file=main.tfvars
   ```

4. **Test** in a non-production AWS account if possible

## Security

- **Never** commit sensitive data (credentials, API keys, etc.)
- **Never** commit Terraform state files
- Review `.gitignore` before committing
- Use AWS Secrets Manager or SSM Parameter Store for secrets
- Report security vulnerabilities privately

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Feel free to open an issue with the `question` label.

---

Thank you for contributing! 🚀
