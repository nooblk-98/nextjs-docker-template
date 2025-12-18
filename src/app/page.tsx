export default function Home() {
    return (
        <main className="flex min-h-screen flex-col items-center justify-center p-24">
            <div className="z-10 max-w-5xl w-full items-center justify-between font-mono text-sm">
                <h1 className="text-4xl font-bold mb-8 text-center">
                    Next.js Docker Template
                </h1>
                <div className="bg-gray-100 dark:bg-gray-800 rounded-lg p-8 shadow-lg">
                    <h2 className="text-2xl font-semibold mb-4">Features</h2>
                    <ul className="space-y-2 list-disc list-inside">
                        <li>✅ Multi-stage Docker build</li>
                        <li>✅ Security hardened (non-root user, read-only filesystem)</li>
                        <li>✅ Performance optimized (standalone output)</li>
                        <li>✅ Health checks included</li>
                        <li>✅ Development & Production configurations</li>
                        <li>✅ Nginx reverse proxy ready</li>
                        <li>✅ Resource limits configured</li>
                    </ul>
                </div>
                <div className="mt-8 text-center text-gray-600 dark:text-gray-400">
                    <p>Edit <code className="bg-gray-200 dark:bg-gray-700 px-2 py-1 rounded">src/app/page.tsx</code> to get started</p>
                </div>
            </div>
        </main>
    );
}
