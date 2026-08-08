import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        generationOptions: .options(
            manifestEnvironment: [
                "JINDOKIT_*",
            ]
        )
    )
)
