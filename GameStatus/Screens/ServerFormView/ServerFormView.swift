//
//  ServerFormView.swift
//  GameStatus
//
//  Created by Tom on 15/06/2025.
//

import SwiftData
import SwiftUI

struct ServerFormView: View {

    let server: GameServer?

    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) var colorScheme

    @StateObject var viewModel: ServerFormViewModel
    @FocusState private var focusedTextField: FormTextField?

    @Binding var isShowing: Bool

    init(server: GameServer?, isShowing: Binding<Bool>) {
        self.server = server
        self._isShowing = isShowing
        _viewModel = StateObject(
            wrappedValue: ServerFormViewModel(server: server)
        )
    }

    enum FormTextField: Hashable {
        case hostname, name
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "server.rack")
                            .resizable()
                            .frame(width: 20, height: 20)
                        TextField(
                            "Hostname - myserver.net",
                            text: $viewModel.serverAddress
                        )
                        .textInputAutocapitalization(.never)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                        .focused(
                            $focusedTextField,
                            equals: FormTextField.hostname
                        )
                        .onSubmit {
                            let addressSplit = viewModel.serverAddress.split(
                                separator: ":"
                            )
                            if addressSplit.count > 1 {
                                viewModel.serverPort = Int(addressSplit[1])
                                viewModel.serverAddress = String(
                                    addressSplit[0]
                                )
                            }
                            if viewModel.serverName.isEmpty {
                                viewModel.serverName =
                                    (addressSplit.count > 1)
                                    ? String(addressSplit[0])
                                    : viewModel.serverAddress
                            }
                            focusedTextField = .name
                        }
                        .onChange(of: focusedTextField) { _, newFocus in
                            if newFocus != .hostname {
                                let addressSplit = viewModel.serverAddress
                                    .split(separator: ":")
                                if addressSplit.count > 1 {
                                    viewModel.serverPort = Int(addressSplit[1])
                                    viewModel.serverAddress = String(
                                        addressSplit[0]
                                    )
                                }
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                                if focusedTextField == .hostname {
                                    HStack {
                                        Button {
                                            UIPasteboard.general.string?
                                                .withCString { cString in
                                                    viewModel.serverAddress =
                                                        String(
                                                            cString: cString
                                                        )
                                                }
                                        } label: {
                                            Image(
                                                systemName:
                                                    "document.on.clipboard.fill"
                                            )
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(
                                                colorScheme == .dark
                                                    ? .white : .black
                                            )
                                            .padding(.horizontal)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .submitLabel(.next)
                    }
                    HStack {
                        Image(systemName: "tag.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                        TextField(
                            "Name - My Server",
                            text: $viewModel.serverName
                        )
                        .disableAutocorrection(true)
                        .focused($focusedTextField, equals: FormTextField.name)
                        .onSubmit { focusedTextField = nil }
                        .submitLabel(.continue)
                    }
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Picker("Type", selection: $viewModel.serverType) {
                            Text("Minecraft Java Edition").tag(
                                GameServerType.minecraft
                            )
                            Text("Minecraft Bedrock Edition").tag(
                                GameServerType.bedrock
                            )
                            Text("Source (CS,TF2,GMod,...)").tag(
                                GameServerType.source
                            )
                            Text("FiveM / RedM").tag(GameServerType.fivem)
                        }
                    }
                    HStack {
                        Image(systemName: "number")
                            .resizable()
                            .frame(width: 20, height: 20)
                        TextField(
                            "Port (Optional)",
                            value: $viewModel.serverPort,
                            format: .number
                        )
                        .keyboardType(.numberPad)
                    }
                } header: {
                    Text("Server Info")
                } footer: {
                    if viewModel.serverType.rawValue
                        == GameServerType.fivem.rawValue
                    {
                        Text(
                            "Following iOS constraints, This server type requires to uses an external API to fetch the server status.\ngamerservertracker.io"
                        )
                    }
                }
            }.navigationTitle(
                Text(server == nil ? "Add a server" : "Edit server")
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if #available(iOS 26, *) {
                        Button {
                            viewModel.save(context: context)
                            isShowing = false
                        } label: {
                            Image(systemName: "checkmark")
                        }.disabled(!viewModel.isValid).tint(viewModel.isValid ? .green : .primary)
                    } else {
                        Button {
                            viewModel.save(context: context)
                            isShowing = false
                        } label: {
                            Text("Save")
                        }.disabled(!viewModel.isValid)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    if #available(iOS 26, *) {
                        Button {
                            isShowing = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    } else {
                        Button {
                            isShowing = false
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ServerFormView(server: nil, isShowing: .constant(true))
        .modelContainer(for: GameServer.self, inMemory: true)
}
