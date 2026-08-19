document.addEventListener('DOMContentLoaded', () => {
    const form =
        document.querySelector('#loginForm') ||
        document.querySelector('form');

    if (!form) {
        console.error('Login form not found');
        return;
    }

    const usernameInput =
        form.querySelector('[name="username"]') ||
        form.querySelector('[name="email"]') ||
        form.querySelector('input[type="email"]');

    const passwordInput =
        form.querySelector('[name="password"]') ||
        form.querySelector('input[type="password"]');

    const message =
        document.querySelector('#loginMessage') ||
        document.querySelector('.login-message');

    function showMessage(text, error = true) {
        if (!message) {
            alert(text);
            return;
        }

        message.textContent = text;
        message.style.display = 'block';
        message.style.color = error ? '#ff6b9d' : '#00ffd1';
    }

    form.addEventListener('submit', async (event) => {
        event.preventDefault();

        const username = String(
            usernameInput?.value || ''
        ).trim();

        const password = String(
            passwordInput?.value || ''
        );

        if (!username || !password) {
            showMessage('يرجى إدخال اسم المستخدم وكلمة المرور');
            return;
        }

        const button =
            form.querySelector('button[type="submit"]') ||
            form.querySelector('button');

        if (button) {
            button.disabled = true;
            button.dataset.originalText = button.textContent;
            button.textContent = 'جاري تسجيل الدخول...';
        }

        try {
            const response = await fetch('/api/auth?action=login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                credentials: 'include',
                body: JSON.stringify({
                    username,
                    password
                })
            });

            const data = await response.json();

            if (!response.ok) {
                throw new Error(
                    data.error || 'فشل تسجيل الدخول'
                );
            }

            showMessage('تم تسجيل الدخول بنجاح', false);

            setTimeout(() => {
                window.location.href = '/';
            }, 500);

        } catch (error) {
            console.error(error);
            showMessage(error.message || 'حدث خطأ أثناء تسجيل الدخول');
        } finally {
            if (button) {
                button.disabled = false;
                button.textContent =
                    button.dataset.originalText || 'تسجيل الدخول';
            }
        }
    });
});
