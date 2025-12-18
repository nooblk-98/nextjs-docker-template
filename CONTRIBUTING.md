# Contributing to Next.js Docker Template

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 🤝 How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Docker version, etc.)
- Relevant logs or screenshots

### Suggesting Enhancements

We welcome suggestions! Please create an issue with:
- Clear description of the enhancement
- Use case and benefits
- Possible implementation approach

### Pull Requests

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/nextjs-docker-template.git
   cd nextjs-docker-template
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the coding standards
   - Add tests if applicable
   - Update documentation

4. **Test your changes**
   ```bash
   # Test locally
   npm run dev
   
   # Test with Docker
   docker build -t nextjs-app:test .
   docker run -p 3000:3000 nextjs-app:test
   
   # Run security scan
   make security-scan
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `style:` Code style changes
   - `refactor:` Code refactoring
   - `test:` Test changes
   - `chore:` Build/tooling changes

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**
   - Provide clear description
   - Reference related issues
   - Include screenshots if applicable

## 📋 Development Guidelines

### Code Style

- Use TypeScript for type safety
- Follow ESLint rules
- Use meaningful variable names
- Add comments for complex logic

### Docker Best Practices

- Keep images small
- Use multi-stage builds
- Minimize layers
- Don't run as root
- Use .dockerignore

### Security

- Never commit secrets
- Use environment variables
- Follow security best practices
- Run security scans

### Testing

- Test locally before pushing
- Test Docker builds
- Verify health checks work
- Check for security vulnerabilities

## 🔍 Review Process

1. Automated checks must pass
2. Code review by maintainers
3. Security scan must pass
4. Documentation must be updated

## 📚 Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Conventional Commits](https://www.conventionalcommits.org/)

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Thank You!

Your contributions help make this project better for everyone!
